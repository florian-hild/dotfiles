import socket
import sys

import pytest

import app.tnsping as tnsping

# ---------------------------------------------------------------------------
# parse_descriptor
# ---------------------------------------------------------------------------


def test_parse_descriptor_success():
    desc = "(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=db01.example.com)(PORT=1521)))"
    host, port = tnsping.parse_descriptor(desc)

    assert host == "db01.example.com"
    assert port == 1521


def test_parse_descriptor_missing_host():
    desc = "(DESCRIPTION=(ADDRESS=(PORT=1521)))"
    with pytest.raises(Exception, match="HOST"):
        tnsping.parse_descriptor(desc)


def test_parse_descriptor_missing_port():
    desc = "(DESCRIPTION=(ADDRESS=(HOST=db01.example.com)))"
    with pytest.raises(Exception, match="PORT"):
        tnsping.parse_descriptor(desc)


# ---------------------------------------------------------------------------
# build_tns_ping_packet
# ---------------------------------------------------------------------------


def test_build_tns_ping_packet_length():
    packet = tnsping.build_tns_ping_packet()
    assert isinstance(packet, bytes)
    assert len(packet) == 99


def test_build_tns_ping_packet_contains_ping():
    packet = tnsping.build_tns_ping_packet()
    assert b"(CONNECT_DATA=(COMMAND=ping))" in packet


# ---------------------------------------------------------------------------
# resolve_tns_alias (LDAP mocked)
# ---------------------------------------------------------------------------


def test_resolve_tns_alias_success(mocker):
    mock_conn = mocker.Mock()
    mock_conn.search_s.return_value = [("cn=test,dc=example,dc=com", {"orclNetDescString": [b"(HOST=db01)(PORT=1521)"]})]
    mocker.patch("app.tnsping.ldap.initialize", return_value=mock_conn)

    desc = tnsping.resolve_tns_alias("test")

    assert "(HOST=db01)" in desc
    mock_conn.simple_bind_s.assert_called_once()
    mock_conn.unbind.assert_called_once()


def test_resolve_tns_alias_not_found(mocker):
    mock_conn = mocker.Mock()
    mock_conn.search_s.return_value = []
    mocker.patch("app.tnsping.ldap.initialize", return_value=mock_conn)

    with pytest.raises(Exception, match="not found"):
        tnsping.resolve_tns_alias("missing")


def test_resolve_tns_alias_missing_descriptor(mocker):
    mock_conn = mocker.Mock()
    mock_conn.search_s.return_value = [("cn=test", {})]
    mocker.patch("app.tnsping.ldap.initialize", return_value=mock_conn)

    with pytest.raises(Exception, match="no connection descriptor"):
        tnsping.resolve_tns_alias("test")


# ---------------------------------------------------------------------------
# tnsping (socket mocked)
# ---------------------------------------------------------------------------


def test_tnsping_success(mocker, capsys):
    mock_socket = mocker.MagicMock()
    mock_socket.recv.return_value = b"\x00\x01"

    # patch socket.create_connection to return a context manager
    mocker.patch(
        "socket.create_connection",
        return_value=mock_socket,
    )
    # support context manager protocol
    mock_socket.__enter__.return_value = mock_socket
    mock_socket.__exit__.return_value = None

    tnsping.tnsping("localhost", 1521, attempts=1, timeout=1)

    out = capsys.readouterr().out
    assert "OK" in out
    mock_socket.sendall.assert_called_once()


def test_tnsping_timeout(mocker, capsys):
    mocker.patch("socket.create_connection", side_effect=socket.timeout)
    tnsping.tnsping("localhost", 1521, attempts=1, timeout=1)

    out = capsys.readouterr().out
    assert "TIMEOUT" in out


def test_tnsping_connection_error(mocker, capsys):
    mocker.patch("socket.create_connection", side_effect=OSError("connection refused"))
    tnsping.tnsping("localhost", 1521, attempts=1, timeout=1)

    out = capsys.readouterr().out
    assert "ERROR" in out


# ---------------------------------------------------------------------------
# main() CLI handling
# ---------------------------------------------------------------------------


def test_main_success_flow(mocker, capsys):
    mocker.patch.object(sys, "argv", ["prog", "test", "1"])
    mocker.patch("app.tnsping.resolve_tns_alias", return_value="(HOST=db)(PORT=1521)")
    mocker.patch("app.tnsping.parse_descriptor", return_value=("db", 1521))
    mocker.patch("app.tnsping.tnsping")

    tnsping.main()

    out = capsys.readouterr().out
    assert "TNS Ping Utility" in out


def test_main_invalid_attempts(mocker, capsys):
    mocker.patch.object(sys, "argv", ["prog", "test", "abc"])
    with pytest.raises(SystemExit):
        tnsping.main()

    out = capsys.readouterr().out
    assert "valid integer" in out


def test_main_empty_alias(mocker):
    mocker.patch.object(sys, "argv", ["prog", ""])
    with pytest.raises(SystemExit):
        tnsping.main()

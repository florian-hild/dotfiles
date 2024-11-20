# Compiler and flags
CC = gcc
CFLAGS = -Wall -Wextra -O2

# Targets
TARGET = bin/check_services
SRCDIR = src
OBJDIR = obj
BINDIR = bin
SRCS = $(wildcard $(SRCDIR)/*.c)
OBJS = $(patsubst $(SRCDIR)/%.c, $(OBJDIR)/%.o, $(SRCS))

# Default rule to build the target
all: $(BINDIR) $(OBJDIR) $(TARGET)

# Link object files to create the executable
$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $(TARGET) $(OBJS)

# Compile source files into object files
$(OBJDIR)/%.o: $(SRCDIR)/%.c
	$(CC) $(CFLAGS) -c $< -o $@

# Create necessary directories
$(BINDIR):
	mkdir -p $(BINDIR)

$(OBJDIR):
	mkdir -p $(OBJDIR)

# Clean up build artifacts
clean:
	rm -rf $(OBJDIR) $(BINDIR)

# Utility rule for debugging
debug: CFLAGS += -g
debug: clean all

# Phony targets
.PHONY: all clean debug


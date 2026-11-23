CC = gcc
CFLAGS = -Wall -Werror -std=gnu11 -O2
LDLIBS = -lm

highway: highway.c
	$(CC) $(CFLAGS) highway.c -o highway $(LDLIBS)

clean:
	rm -f highway

.PHONY: clean

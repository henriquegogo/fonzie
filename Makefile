BINNAME = sefzee
SRC = $(wildcard src/*.c)
CFLAGS = -std=c99 -Wall

all:
	$(CC) -o $(BINNAME) $(SRC) $(CFLAGS)

run:
	./$(BINNAME)

clean:
	rm $(BINNAME)

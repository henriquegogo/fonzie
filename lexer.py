#!/usr/bin/env python

HEADER, OPCODE, VALUE = 'HEADER', 'OPCODE', 'VALUE'
pos = 0

def is_value(text, pos):
    char = text[pos]

    return char >= '0' and char <= '9' \
        or char >= 'A' and char <= 'Z' \
        or char >= 'a' and char <= 'z' \
        or char == '.' \
        or char == ':' \
        or char == '\\' \
        or char == '/' \
        or char == '-' \
        or char == '_' \
        or char == '#' \
        or char == ' ' \
        and not is_end_of_value(text, pos + 1)

def is_end_of_value(text, pos):
    while is_opcode(text[pos]):
        pos += 1
        if is_equal(text[pos]): return True

    if is_comment(text, pos): return True

    return False

def is_header(char):
    return char == '<' \
        or char == '>' \
        or char >= 'a' and char <= 'z'

def is_end_of_header(char):
    return char == '>'

def is_opcode(char):
    return char >= '0' and char <= '9' \
        or char >= 'a' and char <= 'z' \
        or char == '_'

def is_space(char):
    return char == ' ' \
        or char == '\t'

def is_equal(char):
    return char == '='

def is_comment(text, pos):
    return text[pos] == '/' and text[pos + 1] == '/'

def is_newline(char):
    return char == '\n' \
        or char == '\r'

def next_token(text):
    global pos

    if is_space(text[pos]):
        while is_space(text[pos]):
            pos += 1

    if is_newline(text[pos]):
        while is_newline(text[pos]):
            pos += 1

    if is_comment(text, pos):
        while not is_newline(text[pos]):
            pos += 1

    if is_equal(text[pos]):
        type = VALUE
        value = ''
        pos += 1

        while is_value(text, pos):
            value += text[pos]
            pos += 1

        return [type, value]

    elif is_opcode(text[pos]):
        type = OPCODE
        value = ''

        while is_opcode(text[pos]):
            value += text[pos]
            pos += 1

        return [type, value]

    elif is_header(text[pos]):
        type = HEADER
        value = ''

        while is_header(text[pos]) and not is_end_of_header(text[pos - 1]):
            value += text[pos]
            pos += 1

        return [type, value]

def lexer(text):
    tokens = []

    while pos < len(text) - 1:
        token = next_token(text)
        if token: tokens.append(token)

    return tokens

def read_file(filename):
    file = open(filename, 'r', encoding='utf-8')
    text = ''.join(file.readlines())
    return text

def main():
    text = read_file('sample.sfz')
    tokens = lexer(text)
    print(tokens)

if __name__ == '__main__':
    main()

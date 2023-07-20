import struct
import zlib

def inflate(data):
    decompress = zlib.decompressobj(
            -zlib.MAX_WBITS  # see above
    )
    inflated = decompress.decompress(data)
    inflated += decompress.flush()
    return inflated

f = open("flag.zip", "rb")

# parse file entries
while True:
    sig = struct.unpack('i', f.read(4))[0]
    if sig != 0x04034b50:
        break
    f.read(2) # ver
    f.read(2) # flags
    comp = struct.unpack('H', f.read(2))[0] # compression
    f.read(2) # last mod time
    f.read(2) # last mod date
    f.read(4) # crc32
    size_comp = struct.unpack('i', f.read(4))[0] # compressed size
    size_uncomp = struct.unpack('i', f.read(4))[0] # uncompressed size
    name_len = struct.unpack('H', f.read(2))[0] # filename length
    extra_len = struct.unpack('H', f.read(2))[0] # extra field len
    name = f.read(name_len)
    f.read(extra_len)
    data = f.read(size_comp)
    print(name, end=": ")
    if comp == 8:
        data = inflate(data)
        print(data)

while True:
    # parse central directory
    f.read(2) # version made by
    f.read(2) # version needed to extract
    f.read(2) # general purpose flag
    f.read(2) # compression method
    f.read(2) # last file mod time
    f.read(2) # last file mode date
    f.read(4) # crc32
    size_comp = struct.unpack('i', f.read(4))[0] # compressed size
    size_uncomp = struct.unpack('i', f.read(4))[0] # uncompressed size
    name_len = struct.unpack('H', f.read(2))[0] # filename length
    extra_len = struct.unpack('H', f.read(2))[0] # extra field length
    comment_len = struct.unpack('H', f.read(2))[0] # comment length
    f.read(2) # start disk number
    f.read(2) # internal file attributes
    f.read(4) # external file attributes
    f.read(4) # relative offset of local file header
    print(f.read(name_len), end=" ")
    f.read(extra_len)
    print("Comment:", f.read(comment_len))
    sig = struct.unpack('i', f.read(4))[0] # next signature
    if sig != 0x02014b50:
        break

# read end of central directory record
f.read(2) # number of disk
f.read(2) # disk where central directory starts
f.read(2) # number of central directory record on this disk
f.read(2) # total number of central directory records
f.read(4) # size of central directory bytes
f.read(4) # offset of start of central directory
comment_len = struct.unpack('H', f.read(2))[0]
print("Comment:", f.read(comment_len))

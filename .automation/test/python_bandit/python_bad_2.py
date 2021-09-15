# Based on https://github.com/PyCQA/bandit/blob/master/examples/crypto-md5.py
from cryptography.hazmat.primitives import hashes
from Crypto.Hash import MD2 as pycrypto_md2
from Crypto.Hash import MD4 as pycrypto_md4
from Crypto.Hash import MD5 as pycrypto_md5
from Crypto.Hash import SHA as pycrypto_sha
from Cryptodome.Hash import MD2 as pycryptodomex_md2
from Cryptodome.Hash import MD4 as pycryptodomex_md4
from Cryptodome.Hash import MD5 as pycryptodomex_md5
from Cryptodome.Hash import SHA as pycryptodomex_sha
import hashlib

hashlib.md5(1)
hashlib.md5(1).hexdigest()

abc = str.replace(hashlib.md5("1"), "###")

print(hashlib.md5("1"))

hashlib.sha1(1)

pycrypto_md2.new()
pycrypto_md4.new()
pycrypto_md5.new()
pycrypto_sha.new()

pycryptodomex_md2.new()
pycryptodomex_md4.new()
pycryptodomex_md5.new()
pycryptodomex_sha.new()

hashes.MD5()
hashes.SHA1()

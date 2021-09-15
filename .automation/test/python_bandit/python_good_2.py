# Based on https://github.com/PyCQA/bandit/blob/master/examples/crypto-md5.py
from cryptography.hazmat.primitives import hashes
import hashlib

hashlib.sha256(1)
hashlib.sha256(1).hexdigest()

abc = str.replace(hashlib.sha256("1"), "###")

print(hashlib.sha256("1"))

hashlib.blake2b(1)

hashes.BLAKE2b(64)
hashes.SHA3_512()

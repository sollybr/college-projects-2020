"""
TCP Mail client -- Kurose 6ed
sollybr -- cavalcante.matias@aluno.uece.br
2020-12-22
"""

# import smtplib
import getpass
import socket
# import regex
# import ssl

RTSY = b'\r\n'
MAILSERVER, PORT = 'localhost', 587
# Choose a mail server (e.g. Google mail server) and call it mailserver

def main (user='example@example.com', password : str = '123456'):
	msg = RTSY+b'We live in a society!'
	endmsg = RTSY+b'.'+RTSY

	with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as skt:
		""" Create socket called skt and establish 
		a TCP connection with mailserver """
		
		skt.connect((MAILSERVER, PORT))
		recv = skt.recv(1024)
		print(recv)
		if recv[:3] != b'220':
			print('220 reply not received from server.')
		else:

			salute = b'HELO myclient.example'
			skt.send(salute)
			recv = skt.recv(1024)
			print(recv)
			if recv[:3] != b'250':
				print('250 reply not received from server.')
			else:
				# Send MAIL FROM command and print server response.
				# Fill in start
				MAIL_FROM = b'MAIL FROM:<' + bytes(user, 'utf-16') + b'>'
				skt.send(MAIL_FROM)
				recv = skt.recv(1024)
				print(recv)
				# Fill in end

				# Send RCPT TO command and print server response.
				# Fill in start
				RCPT_TO = b'RCPT TO:<' + bytes(user, 'utf-16') + b'>'
				skt.send(RCPT_TO)
				recv = skt.recv(1024)
				print(recv)
				# Fill in end

				# Send DATA command and print server response.
				# Fill in start
				skt.send(b'DATA')
				recv = skt.recv(1024)
				print(recv)
				# Fill in end

				# Send message data.
				# Fill in start
				skt.send(msg)
				recv = skt.recv(1024)
				print(recv)
				# Fill in end

				# Message ends with a single dot.
				# Fill in start
				skt.send(endmsg)
				recv = skt.recv(1024)
				print(recv)
				# Fill in end

				# Send QUIT command and get server response.
				# Fill in start
				skt.send(RTSY+b'QUIT')
				recv = skt.recv(1024)
				print(recv)
				# Fill in end

if __name__ == '__main__':
	user = ''
	while '@' and '.com' not in user:
		user = str(input(prompt='Type user: '))

	main(user, getpass.getpass(prompt='Type pw: ', stream=None))


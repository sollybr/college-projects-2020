#include <sys/socket.h>
#include <arpa/inet.h>
#include <sys/time.h>
#include <unistd.h>
#include <string.h>
#include <stdio.h>

#define PORT 42069
#define BUFFER_SZ 64


struct timeval __to;
struct fd_set sfds;
struct sockaddr_in server;
int sckt, len = sizeof(server);

char talk(char * msg, char * buffer){
	if (sendto(
		sckt,
		(const char*)msg,
		strlen(msg)+1,
		0,
		(const struct sockaddr*)&server,
		sizeof(server)
		) < 0) return 0;

	(select(sckt+1, &sfds, NULL, NULL, &__to) > 0) ?
		recvfrom(sckt, 
			buffer, 
			BUFFER_SZ, 
			0, 
			(struct sockaddr*)&server, 
			&len) && printf("%s\t", buffer) : printf("MISSED\t");
	return 1;
}

int main(int argc, char const *argv[])
{
	short __i = 0; 
	char msg[] = "ping\0", buffer[BUFFER_SZ];

	if ((sckt=socket(AF_INET, SOCK_DGRAM, 0)) < 0) return 1;
	if (setsockopt(
		sckt, 
		SOL_SOCKET, 
		SO_RCVTIMEO,
		(char*)&__to,
		sizeof(__to)
		) < 0) return 2;

	__to.tv_sec = 1;
	FD_SET(sckt, &sfds);

	{
		server.sin_family = AF_INET;
		server.sin_addr.s_addr = INADDR_ANY;
		server.sin_port = htons(PORT);
	}	// Define versão prot. IP, endereço de servidor e porta da aplicação

	while (__i < 10) {
		struct timeval stop, start;
		gettimeofday(&start, NULL);
		talk(msg, buffer);
		gettimeofday(&stop, NULL);
		printf(
			"%lu μs\n", 
			(stop.tv_sec - start.tv_sec) * 1000000 + stop.tv_usec-start.tv_usec
				);
		fflush(stdout);
		sleep(1);
		__i++;
	} //	Envia mensagem e verifica tempo de resposta 10 vezes.

	close(sckt);
}
#include <sys/socket.h>
#include <arpa/inet.h>
// #include <unistd.h>
#include <string.h>
#include <stdio.h>

#define PORT 42069
#define BUFFER_SZ 64

int main(/*int argc, char const *argv[]*/)
{
	struct sockaddr_in server, client;

	char qst[] = "ping\0", ans[] = "pong\0", buffer[BUFFER_SZ];
	int sckt, len = sizeof(client), type = SOCK_DGRAM;
	if ((sckt=socket(AF_INET, type, 0)) < 0) return 1;

	server.sin_family = AF_INET;
	server.sin_addr.s_addr = INADDR_ANY;
	server.sin_port = htons(PORT);

	if (bind(sckt, (const struct sockaddr *)&server, sizeof(server)) < 0) 
		return 2;

	while (1){
		recvfrom(
			sckt, 
			buffer, 
			BUFFER_SZ,
			0,
			&client,
			&len
			);

		(strcmp(buffer, qst) == 0) ? sendto(
			sckt,
			(const char*)ans,
			strlen(ans)+1,
			0,
			(const struct sockaddr*)&client,
			sizeof(client)
			) && printf("%s\n", buffer) : printf("Invalid: %s\n", buffer);
	}
}

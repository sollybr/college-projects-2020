#include <sys/socket.h>
#include <arpa/inet.h>
#include <netinet/in.h>

// #include <unistd.h>
#include <string.h>
#include <stdio.h>

#include <time.h>

#define PORT 42069
#define PORT_TCP 8080
#define BUFFER_SZ 64

int main(int argc, char const *argv[])
{
	struct sockaddr_in server, client;

	char qst[] = "GET_TIME\0", buffer[BUFFER_SZ];
	time_t now; struct tm * ans;
	int sckt = -1, comm_skt = -1, len = sizeof(client), 
	type = (argc > 1 && strcmp(argv[1], "--tcp") == 0) ? 
	SOCK_STREAM : SOCK_DGRAM;
	
	if ((sckt=socket(AF_INET, type, 0)) < 0) return 1;

	server.sin_family = AF_INET;
	inet_aton("127.0.0.1", 
		(struct in_addr*)&server.sin_addr.s_addr);
	// server.sin_addr.s_addr = INADDR_ANY;
	server.sin_port = htons((type == SOCK_DGRAM) ? PORT : 8080);
	// printf("%s\n", inet_ntoa(server.sin_addr));

	if (bind(sckt, (const struct sockaddr *)&server, sizeof(server)) < 0) 
		return 2;
	
	type == SOCK_DGRAM ? recvfrom(
		sckt, 
		buffer, 
		BUFFER_SZ,
		0,
		(struct sockaddr *)&client,
		&len
		) : (listen(sckt, 10) == 0 ? 
			(
				(comm_skt=accept(
					sckt, 
					(struct sockaddr*)&client, 
					&len)
				) >= 0 && recv (comm_skt, buffer, BUFFER_SZ, 0)
			) : printf("Unable to listen\n"));

	time(&now); ans = localtime(&now);

	strcmp(buffer, qst) == 0 ? 
		(
			(
				type == SOCK_DGRAM ? 
				sendto(sckt, ans, sizeof(*ans), 0, 
					(const struct sockaddr*) &client, len) 
				/*&& printf(
					"%s\t%s\n", 
					buffer, 
					inet_ntoa(client.sin_addr))*/ :
					(comm_skt >= 0 ?
						send(comm_skt, ans, sizeof(*ans), 0) :
						printf("Communication failed.\n"))
			)
		) : printf("Invalid request: \"%s\"\n", buffer);
	
}

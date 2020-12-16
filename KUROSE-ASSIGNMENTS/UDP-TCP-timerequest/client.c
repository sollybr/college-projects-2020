#include <sys/socket.h>
#include <arpa/inet.h>

#include <unistd.h>
#include <string.h>
#include <stdio.h>
#include <time.h>

#define PORT 42069
#define PORT_TCP 8080
#define BUFFER_SZ 64

struct sockaddr_in server;
int sckt, len = sizeof(server);

int talk(char * msg, char * buffer, int type){
	if ((type == SOCK_DGRAM ? sendto(
		sckt,
		(const char*)msg,
		strlen(msg)+1,
		0,
		(const struct sockaddr*)&server,
		sizeof(server)
		) : send(sckt, msg, strlen(msg)+1, 0)) < 0) return 0;

	return (type == SOCK_DGRAM) ? recvfrom(
		sckt, buffer, BUFFER_SZ, 
		0, (struct sockaddr*)&server, &len
		) : recv(sckt, buffer, BUFFER_SZ, 0);
}

int main(int argc, char const *argv[])
{
	int type = (argc > 1 && strcmp(argv[1], "--tcp") == 0) ? 
	SOCK_STREAM : SOCK_DGRAM;
	char msg[] = "GET_TIME\0", buffer[BUFFER_SZ];
	struct tm ans; int ansSz;
	
	if ((sckt=socket(AF_INET, type, 0)) < 0) return 1;

	server.sin_family = AF_INET;
	inet_aton("127.0.0.1", 
		(struct in_addr*)&server.sin_addr.s_addr);
	server.sin_port = htons((type == SOCK_DGRAM) ? PORT : 8080);
	
	if (type == SOCK_STREAM && 
		(ansSz=connect(sckt, (struct sockaddr*)&server, sizeof(server)) != 0)) 
		{ printf("oof: %d\n", ansSz); return 2;}

	if ((ansSz=talk(msg, buffer, type)) > 0) {
		memcpy(&ans, buffer, ansSz);
		printf("%s\n", asctime(&ans));
	} else return 3;

	close(sckt);
}
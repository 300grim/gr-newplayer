# gr-newplayer
A way to identify new players on a qb-core server.

Features a command for disabling the halo if the new player does not want to see it. (/halo).

Only allows new players access to the halo for 2 weeks. 

If you have an existing server, and dont want old players to have access to the halo for two weeks - than run this SQL query before your players connect. 
```UPDATE players SET metadata = JSON_SET(metadata, '$.first_joined', 0) WHERE citizenid IS NOT NULL;```


<img width="717" height="709" alt="image" src="https://github.com/user-attachments/assets/d29941f1-97a1-4640-b55b-9fe86a6ceef0" />
<img width="353" height="134" alt="image" src="https://github.com/user-attachments/assets/9a699d04-e361-431b-a4f4-388b2269c29b" />


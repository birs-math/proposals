# Proposals

"Proposals" is a web application for accepting proposals for scientific meetings, such as workshops or conferences, and facilitating the peer-review and selection process at [BIRS](https://www.birs.ca).

See [the wiki](https://github.com/birs-math/proposals/wiki) for the intial specifications.


## Setup Instructions

1. Copy the `docker-compose.yml.example` file to `docker-compose.yml`.

2. Create the data containers if necessary, for persistent storage, as described at the top of the file.

3. Fill in the environment variables for usernames & passwords, and various seed keys, in the file.

4. ```docker-compose up``` to build & run the containers.

5. ```docker exec -it proposals bash``` to get a shell.

Alternatively:

1. Copy `.env.rb.example` to `.env.rb` and add your env variables.

[![Codacy Badge](https://app.codacy.com/project/badge/Grade/dea8bb805d7444c78381750c42b30502)](https://www.codacy.com/gh/birs-math/proposals/dashboard?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=birs-math/proposals&amp;utm_campaign=Badge_Grade)

[![Codacy Badge](https://app.codacy.com/project/badge/Coverage/dea8bb805d7444c78381750c42b30502)](https://www.codacy.com/gh/birs-math/proposals/dashboard?utm_source=github.com&utm_medium=referral&utm_content=birs-math/proposals&utm_campaign=Badge_Coverage)

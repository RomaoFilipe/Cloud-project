
# DEV MEETING - Jun, 05, 2024

## Starting from scratch

- one unique machine for load balancing
- 2 web-servers (min)
- 1 DB
- One should be able to access our website through `HOSTNAME` 
- Important IP Address: http://192.168.44.10

Try to `serve`.


## Second Step

If successful, try to implement HA (High availability) on `Load Balancer` layer.

- 2 nodes for load balancing
- web server layer `with 3 nodes`


## Third step

`Monitoring` tool implementation with service discovery (`consul`)

## Fourth step

HA (High Availability) on `database layer`

Attention to:

- Check how current DB is structured and it tables.

possiblity 1:

- Each server is responsible for one exclusive column or table.
- Example for possibility 1: Lets assume we have only 3 tables, then, we would need 3 different servers.
- Security policy: in case of failure, try to handle failed server to the index before. If 2 Fails, try and go to 1
- Naming policy: db-[index-of-server]. Example --> db-1, db-2, db-3

## Fifth step

Storage is now `modular`

Just one server without HA. Why?? We must look out for our limited resources and therefore, it wouldn´t be possibly to achieve
all that with our local machines.


## Sixth step

Physical infra distribution

- 3 different computers with the whole system for each one



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

## Fifth step

Storage is now `modular`

## Sixth step

Physical infra distribution

- 3 different computers with the whole system for each one


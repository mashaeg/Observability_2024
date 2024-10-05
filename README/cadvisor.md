## Check Traefik Dashboard

Verify the cAdvisor service is properly routed in the Traefik dashboard:  
[Traefik Dashboard](http://192.168.0.24:8080/dashboard/#/).  
The routing for cAdvisor should be visible there.

## Test Both Access Points

Now, check if both access points work:

- **Direct cAdvisor access:** [http://192.168.0.24:8081/metrics](http://192.168.0.24:8081/metrics)
- **Traefik proxied access:** [http://192.168.0.24/metrics](http://192.168.0.24/metrics)

# Java EE 7 Samples
  The project will consist  of a simple project with JAX-RS and CDI
  
## To follow the example presented here you will need:

* Java 8 JDK
* Maven
* IDE: Eclipse, IntelliJ, Netbeans
* A JavaEE application server: Wildfly, Payara, Glassfish, Apache TomEE
  
## Run sample

* wildfly-swarm

  ``mvn clean package -P wildfly-swarm``
  
  ``java -jar target/javaee-swarm.jar``

The endpoint is: http://localhost:8080/rest/calculate/doubleOf/10

* payara-micro
    
   ``mvn clean install``
        
   ``java -jar payara-microprofile-<version>.jar --deploy target/javaee.war --outputUberJar javaee.jar``
   
   ``java -jar javaee.jar``
  
### Payara Micro URLs

http://[hostname]:8080/javaee

'javaee' REST Endpoints

>GET	/javaee/rest/calculate/doubleOf/{number}

>GET	/javaee/rest/hello


  

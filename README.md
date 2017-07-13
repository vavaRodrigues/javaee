# Java EE 7 Samples
  The project will consist  of a simple project with JAX-RS and CDI
  
## To follow the example presented here you will need:

* Java 8 JDK
* Maven
* IDE: Eclipse, IntelliJ, Netbeans
* A JavaEE application server: Wildfly, Payara, Glassfish, Apache TomEE
  
## Run sample

* Build the sample that you want to run as

  ``mvn clean package -P wildfly-swarm``
  
  ``java -jar target/javaee-swarm.jar``
  
 The endpoint is: http://localhost:8080/rest/calculate/doubleOf/10
  

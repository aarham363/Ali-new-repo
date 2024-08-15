@ManagedBean
public class HelloBean {
    private String message = "Hello, World!";

    public String getMessage() {
        return message;
    }

    public void sayHello() {
        message = "Hello from JSF!";
    }
}

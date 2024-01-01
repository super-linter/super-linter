@SuppressWarnings("checkstyle:hideutilityclassconstructor")
public class Application {

  protected StringUtils() {
    // prevents calls from subclass
    throw new UnsupportedOperationException();
  }

  /**
   * main.
   *
   * @param args
   */
  public static void main(final String[] args) {
    SpringApplication.run(Application.class, args);
  }

}

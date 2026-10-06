import java.util.HashMap;
import java.util.Map;

/**
 * Imperative counterpart to Expr.eval used only for an optional benchmark.
 * It uses a tag, a switch statement, a mutable HashMap, and exceptions.
 */
public final class ImperativeBenchmark {
    private static final int DEFAULT_ITERATIONS = 5_000_000;

    private enum Kind { LIT, VAR, ADD, SUB, MUL, DIV }

    private static final class Node {
        final Kind kind;
        final double value;
        final String name;
        final Node left;
        final Node right;

        private Node(Kind kind, double value, String name, Node left, Node right) {
            this.kind = kind;
            this.value = value;
            this.name = name;
            this.left = left;
            this.right = right;
        }

        static Node lit(double value) {
            return new Node(Kind.LIT, value, null, null, null);
        }

        static Node variable(String name) {
            return new Node(Kind.VAR, 0, name, null, null);
        }

        static Node binary(Kind kind, Node left, Node right) {
            return new Node(kind, 0, null, left, right);
        }
    }

    private static final Node WORKLOAD =
        Node.binary(
            Kind.DIV,
            Node.binary(
                Kind.ADD,
                Node.binary(Kind.MUL, Node.variable("x"), Node.lit(3.5)),
                Node.binary(Kind.SUB, Node.variable("y"), Node.lit(2))
            ),
            Node.lit(2)
        );

    private ImperativeBenchmark() {}

    private static double eval(Map<String, Double> environment, Node expression) {
        switch (expression.kind) {
            case LIT:
                return expression.value;
            case VAR:
                Double value = environment.get(expression.name);
                if (value == null) {
                    throw new IllegalArgumentException(
                        "undefined variable: " + expression.name
                    );
                }
                return value;
            case ADD:
                return eval(environment, expression.left)
                    + eval(environment, expression.right);
            case SUB:
                return eval(environment, expression.left)
                    - eval(environment, expression.right);
            case MUL:
                return eval(environment, expression.left)
                    * eval(environment, expression.right);
            case DIV:
                double denominator = eval(environment, expression.right);
                if (denominator == 0) {
                    throw new ArithmeticException("division by zero");
                }
                return eval(environment, expression.left) / denominator;
            default:
                throw new IllegalArgumentException("unknown expression tag");
        }
    }

    private static double runEvaluations(int count) {
        Map<String, Double> environment = new HashMap<>();
        double checksum = 0;

        for (int remaining = count; remaining > 0; remaining--) {
            environment.put("x", (double) (remaining % 97));
            environment.put("y", (double) (remaining % 53));
            checksum += eval(environment, WORKLOAD);
        }

        return checksum;
    }

    public static void main(String[] args) {
        int iterations = parseIterations(args);
        int warmupIterations = Math.min(250_000, Math.max(1, iterations / 10));

        // Warm up the JVM's just-in-time compiler before measuring.
        runEvaluations(warmupIterations);

        long start = System.nanoTime();
        double checksum = runEvaluations(iterations);
        long end = System.nanoTime();

        double elapsedSeconds = (end - start) / 1_000_000_000.0;
        double evaluationsPerSecond = iterations / elapsedSeconds;

        System.out.println("Implementation: imperative Java evaluator");
        System.out.printf("Iterations: %d%n", iterations);
        System.out.printf("Checksum: %.6f%n", checksum);
        System.out.printf("Elapsed seconds: %.6f%n", elapsedSeconds);
        System.out.printf("Evaluations/second: %.0f%n", evaluationsPerSecond);
        System.out.printf("TIME_SECONDS=%.9f%n", elapsedSeconds);
        System.out.printf("CHECKSUM=%.6f%n", checksum);
    }

    private static int parseIterations(String[] args) {
        if (args.length == 0) {
            return DEFAULT_ITERATIONS;
        }

        try {
            int value = Integer.parseInt(args[0]);
            return value > 0 ? value : DEFAULT_ITERATIONS;
        } catch (NumberFormatException ignored) {
            return DEFAULT_ITERATIONS;
        }
    }
}

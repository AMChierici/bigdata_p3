package job;

import org.apache.spark.ml.classification.LogisticRegression;
import org.apache.spark.ml.classification.LogisticRegressionModel;
import org.apache.spark.sql.Dataset;
import org.apache.spark.sql.Row;
import org.apache.spark.sql.SparkSession;

public class App 
{
    public static void main( String[] args )
    {
        // create a spark session
        SparkSession spark = SparkSession.builder().appName("Application").getOrCreate();

        //get data
        Dataset<Row> training = spark.read().format("libsvm")
          .load("sample_libsvm_data.txt");

        //create a model    
        LogisticRegression lr = new LogisticRegression()
          .setMaxIter(10)
          .setRegParam(0.3)
          .setElasticNetParam(0.8);

        // Fit the model
        LogisticRegressionModel lrModel = lr.fit(training);

        // Print the coefficients and intercept for logistic regression
        System.out.println("Coefficients: "
          + lrModel.coefficients() + " Intercept: " + lrModel.intercept());
    }
}

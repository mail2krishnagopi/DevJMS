public class giic_ExceptionUtil {
    
    public class MyException extends Exception {
        
    }
    
    @InvocableMethod(label = 'Invoke ExceptionUtil')
    public static void throwCustomException(){
        throw new MyException('Please enter the Travel time in hours');
    }

}
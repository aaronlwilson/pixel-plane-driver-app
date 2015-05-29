
static class Utils {
 
 static public int[] find2DIndex(Object[][] array, Object search) {
   if (search == null || array == null) return null;
   
    for (int rowIndex = 0; rowIndex < array.length; rowIndex++ ) {
       Object[] row = array[rowIndex];
       if (row != null) {
          for (int columnIndex = 0; columnIndex < row.length; columnIndex++) {
             if (search.equals(row[columnIndex])) {
                 int[] point = new int[2];
                 point[0] = rowIndex;
                 point[1] = columnIndex;
                 return point;
             }
          }
       }
    }
    return null; // value not found in array
 }//end find2DIndex
 
 static public int[][] rotateArrayClockwise(int[][] sourceArray){
    //rotate a 2D array
    int[][] rotatedArray = new int[12][12];
    for (int j=0; j<12; j++){
      for (int i=0; i<12; i++){
        rotatedArray[j][i] = sourceArray[i][12-j-1];
      }
    }
    return rotatedArray;
 }
 
 //COLOR utility methods
  static public int getR(color c) {
    return c >> 16 & 0xFF;
  }
  static public int getG(color c) {
    return c >> 8 & 0xFF;
  }
  static public int getB(color c) {
    return c & 0xFF;
  }
 
  static public float getPercent(int loaded, int total){
    return ((float)loaded/total) * 100;
  }
  /*
  static public float percentOf(float loaded, float total){
    return ((loaded/100)*total);
  }
  */
  
  //function to mix 2 values (a,b) by the given mix
  //mix is the percent to mix b with a
  static public int mix(int a,int b, float mix){
    float results = (float) ((a*(100-mix)+b*mix)*0.01);
    return (int) (results);
  }
  
  static public PImage getScreen(int x, int y, int width, int height) {
    GraphicsEnvironment ge = GraphicsEnvironment.getLocalGraphicsEnvironment();
    GraphicsDevice[] gs = ge.getScreenDevices();
    //DisplayMode mode = gs[0].getDisplayMode();
    Rectangle bounds = new Rectangle(x, y, width, height);
    BufferedImage desktop = new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB);
    
    try {
      desktop = new Robot(gs[0]).createScreenCapture(bounds);
    }
    catch(AWTException e) {
      System.err.println("Screen capture failed.");
    }

    return (new PImage(desktop));
  }//end getScreen
 
}





 

    

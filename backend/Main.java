
package com.cyat.backend;

public class Main {
    public static void main(String[] args) {
        System.out.println("Backend service for GitOps project running...");
        
        // Keep the application running
        while(true) {
            try {
                Thread.sleep(60000); // Sleep for 1 minute
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }
}
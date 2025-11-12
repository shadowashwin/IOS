# Rules to fix the "Missing class proguard.annotation" error
-dontwarn proguard.annotation.Keep
-dontwarn proguard.annotation.KeepClassMembers

# Standard rules required by the Razorpay SDK
-keepattributes *Annotation*
-dontwarn com.razorpay.**
-keep class com.razorpay.** {*;}
-optimizations !method/inlining/
-keepclasseswithmembers class * {
    public void onPayment*(...);
}
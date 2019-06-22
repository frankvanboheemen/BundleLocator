
# Let your app move itself to 'Applications' on (initial) launch

This project is an example of a simple class that helps you streamline the experience of first use of your application by allowing your app to 'install itself'. This is especially useful in combination with an update framework such as Sparkle.

**important note**: To make this work, your app should not be sandboxed and your app should not automatically launch it's initial viewcontroller. This has to be done programmatically after the BundleLocator has done its job.

---
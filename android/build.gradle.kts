allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://jitpack.io") }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
// Ensure app project is evaluated first
project.evaluationDependsOn(":app")

subprojects {
    // Workaround for plugins that expect flutter extension properties from legacy Flutter Gradle Plugin
    if (project.name != "app") {
        afterEvaluate {
            if (project.extensions.findByName("android") != null) {
                project.extensions.extraProperties.apply {
                    if (!has("flutter")) {
                        set("flutter", mapOf(
                            "compileSdkVersion" to 34,
                            "minSdkVersion" to 23,
                            "targetSdkVersion" to 34,
                            "ndkVersion" to "25.1.8937393"
                        ))
                    }
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

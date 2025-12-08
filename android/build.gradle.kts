import org.gradle.api.file.Directory
import org.gradle.api.tasks.Delete

// --- GLOBAL REPOSITORIES ---
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// --- FLUTTER BUILD DIRECTORY REDIRECTION ---
val newBuildDir: Directory = rootProject.layout.buildDirectory
    .dir("../../build")
    .get()

rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubBuildDir)
    project.evaluationDependsOn(":app")
}

// --- CLEAN TASK ---
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
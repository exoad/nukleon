plugins {
    id("java")
    kotlin("jvm")
}

group = "net.exoad"
version = "1.0-SNAPSHOT"

repositories {
    mavenCentral()
}

dependencies {
    testImplementation(platform("org.junit:junit-bom:5.10.0"))
    testImplementation("org.junit.jupiter:junit-jupiter")
    implementation("com.badlogicgames.gdx:gdx-tools:1.13.1")
}

tasks.test {
    useJUnitPlatform()
}
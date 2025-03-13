plugins {
	id("java")
	id("application")
	kotlin("jvm")
}
group="net.exoad"
version="1.0-SNAPSHOT"
repositories {
	mavenCentral()
}

dependencies {
	testImplementation(platform("org.junit:junit-bom:5.10.0"))
	testImplementation("org.junit.jupiter:junit-jupiter")
	implementation("com.badlogicgames.gdx:gdx-tools:1.13.1")
	implementation(kotlin("stdlib-jdk8"))
}
application {
	mainClass="net.exoad.nukleon.tools.texturemapper.Main"
}
tasks.test {
	useJUnitPlatform()
}
kotlin {
	jvmToolchain(17)
}
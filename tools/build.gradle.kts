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
	testImplementation(kotlin("test"))
	testImplementation("org.junit.jupiter:junit-jupiter")
	implementation("com.fleeksoft.ksoup:ksoup:0.2.2")
	implementation(kotlin("stdlib-jdk8"))
}

application {
	mainClass="net.exoad.nukleon.tools.bindings.Bindings"
}
tasks.test {
	useJUnitPlatform()
}
kotlin {
	jvmToolchain(17)
}
@echo off
echo Setting JAVA_HOME to JDK 21...
set JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-21.0.9.10-hotspot
set PATH=%JAVA_HOME%\bin;%PATH%

echo Current Java version:
java -version

echo.
echo Building with Maven...
mvnw.cmd clean compile -DskipTests

echo.
echo Build complete!
pause

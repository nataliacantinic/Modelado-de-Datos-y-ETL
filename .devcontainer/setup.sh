#!/usr/bin/env bash
set -euo pipefail

CONNECTOR_VERSION="9.7.0"
JAR_DIR="drivers"
JAR_PATH="${JAR_DIR}/mysql-connector-j.jar"

echo "=== [1/4] Instalando paquetes Python ==="
pip install --upgrade pip --quiet
pip install --no-cache-dir -r .devcontainer/requirements.txt

echo "  Registrando kernel de Jupyter..."
python -m ipykernel install --user --name python3 --display-name "Python 3"

echo "=== [2/4] Descargando MySQL Connector/J ${CONNECTOR_VERSION} ==="
mkdir -p "${JAR_DIR}"

if [ -f "${JAR_PATH}" ]; then
  echo "  JAR ya existe, omitiendo descarga."
else
  curl -fL -o "${JAR_PATH}" \
    "https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/${CONNECTOR_VERSION}/mysql-connector-j-${CONNECTOR_VERSION}.jar"
  echo "  Descargado en ${JAR_PATH}"
fi

echo "=== [3/4] Verificando Java ==="
java -version

echo "=== [4/4] Verificando PySpark ==="
python - <<'EOF'
from pyspark.sql import SparkSession
spark = SparkSession.builder.master("local[1]").appName("smoke-test").getOrCreate()
spark.range(1).count()
spark.stop()
print("  PySpark OK")
EOF

echo ""
echo "Entorno listo."

# Source the JARVICE job environment variables
[[ -r /etc/JARVICE/jobenv.sh ]] && source /etc/JARVICE/jobenv.sh

# Wait for slaves...max of 60 seconds
SLAVE_CHECK_TIMEOUT=60
TOOLSDIR="/usr/local/JARVICE/tools/bin"
${TOOLSDIR}/python_ssh_test ${SLAVE_CHECK_TIMEOUT}
ERR=$?
if [[ ${ERR} -gt 0 ]]; then
  echo "One or more slaves failed to start" 1>&2
  exit ${ERR}
fi

# start SSHd
if [[ -x /usr/sbin/sshd ]]; then
  sudo service ssh start
fi

set -e

# parse command line
CASE="/data/openfoam7/run"
MESHTYPE="blockMesh"
SOLVER="laplacianFoam"

while [[ -n "$1" ]]; do
  case "$1" in
  -case)
    shift
    CASE="$1"
    ;;
  -mesh)
    MESHTYPE="true"
    ;;
  -meshtype)
    shift
    MESHTYPE="$1"
    ;;
  -solver)
    shift
    SOLVER="$1"
    ;;
  *)
    echo "Invalid argument: $1" >&2
    exit 1
    ;;
  esac
  shift
done

# add override for the OpenFOAM project dir
echo "WM_PROJECT_USER_DIR=/data/openfoam" | sudo tee -a "$FOAMETC"/prefs.sh >/dev/null
export WM_PROJECT_USER_DIR=/data/openfoam

# create the working dir, the "run" dir where files go, matches to FOAM_RUN in env
mkdir -p /data/openfoam7/run

# select Case dir, strip file name off path
CASE=$(dirname "$CASE")
echo "Using OpenFOAM Case directory: $CASE"
cd "$CASE"

if [[ -f /opt/openfoam7/etc/bashrc ]]; then
  echo "Sourcing OpenFOAM environment"
  source /opt/openfoam7/etc/bashrc || return
else
  echo "ERROR: OpenFOAM environment unavailable"
  exit 1
fi

# decompose prepped Mesh option

# run selected mesh and log
echo "Running selected mesh and logging to $CASE/case.log"
$MESHTYPE | tee -a "$CASE"/case.log

# set initial fields
echo "Running setFields and logging to $CASE/case.log"
setFields | tee -a "$CASE"/case.log

# run solver on mesh with MPI
$SOLVER | tee -a "$CASE"/case.log

# post-process prep: reconstruct mesh

const baseUrl = "http://ec2-54-157-183-111.compute-1.amazonaws.com/api"

const newTaskInput = document.getElementById("newTask")
const addBtn = document.getElementById("addBtn")

let deleteTaskBtns;
const tasksListElement = document.getElementById("tasksList")

const getTasks = async () => {
  try{
    const response = await axios.get(`${baseUrl}/get/`);
    return response.data.row
  }
  catch(e){
    console.error(e)
  }
};

const init = async () => {

  addBtn.onclick = async () => {
    const taskName = newTaskInput.value

    try{
      const response = await axios.post(`${baseUrl}/add/`, {task:taskName});
      location.reload() //reload the page
    } catch (e) {
      console.error("Error adding the task: ", e);
    }

    addDoc(tasksRef, {
      uid: user.uid,
      name: `${taskName}`,
      createdAt: serverTimestamp()
    }).then(
        console.log("successfully added!!")
    ).then(
      newTaskInput.value = ''
    )
    .catch((e)=>{
        console.error("Error adding document: ", e);
    });
  }

  //show tasks
  const tasksList = await getTasks()
  const items = tasksList.map((task) => {
    return `<li> ${task.task} <button id="deleteTask" data-taskid="${task.id}" class="btn btn-warning">Delete</button> </li>`
  })

  tasksListElement.innerHTML = items.join('');

  deleteTaskBtns = document.querySelectorAll("#deleteTask")
  for (let i = 0; i < deleteTaskBtns.length; i++) {
    deleteTaskBtns[i].addEventListener('click', async function(){
      const taskId = this.dataset.taskid
      try{
        const response = await axios.post(`${baseUrl}/delete/`, {id:taskId});
        location.reload() //reload the page
      } catch (e) {
        console.error("Error adding the task: ", e);
      }
    });
  }

}

 init();
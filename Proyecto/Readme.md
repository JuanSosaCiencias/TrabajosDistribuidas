Integrantes del equipo: 

Ángeles Sánchez Aldo Javier 320286144
Sánchez Victoria Leslie Paola 320170513
Sosa Romo Juan Mario - 320051926

Descripción del proyecto:

El proyecto final de la materia Computacion Distribuida consiste en desarrollar una blockchain para un sistema de criptomonedas. Este sistema debera ser capaz de manejar multiples procesos en Elixir  que representen a los usuarios, quienes podran enviarse mensajes, alcanzar un consenso y detectar y  eliminar procesos maliciosos que intenten alterar la blockchain.

Como usar el proyecto: 

Dentro de la carpeta de src del Proyecto, hay 2 archivos, 'interp.sh' y 'run.sh', estos son la manera mas rapida de correr el proyecto, escencialemnte solo hacen una compilación y agregan todos los archivos del mix al run. Para usarlos, comenzamos por hacer 

> chmox +x interp.sh run.sh

Una vez agregados estos permisos a estos archivos tenemos 2 opciones, 

> './run.sh'

Esta opción solo va a correr el Main con su funcion run con los parametros 10 y 1, crea una red de 10 procesos con 1 proceso bizantino, asigna sus vecinos siguiendo el modelo de Wartz y Strogatz, crea un bloque valido y lo envia al primer proceso para que este lo proponga, cada nodo imprime si lo agrego y nos deja verificar la blockchain de cada uno. 
Posteriormente crea un bloque invalido e igualmente intenta consensuarlo, como es invalido este no entra a las BC, al final nos imprime las BC de todos los nodos, agrego el valido y no agrego el invalido.

La otra opcion, es mas util si queremos jugar con el programa un poquito mas:

> './interp.sh'

Esta opcion solamente nos mete al interprete de elixir con todos los programas compilados y cargados, de aqui podemos hacer uso de varias cosas pero yo recomiendo lo siguiente:

'
iex(*)> procesos = Main.run(10,1)
iex(*)> [normal | _] = procesos
iex(*)> send(normal, {:bloque, Block.new("Bloque 2", "<hash del ultimo bloque>")})
iex(*)> Enum.each(procesos, fn pid -> send(pid, {:estado, nil}) end)
'

Lo anterior envia un bloque nuevo a un proceso cualquiera y si esta bien el hash y el bloque es normal entonces la ultima linea nos deberia enseñar que el bloque se agrego a todas las BC.

Por otro lado tambien recomiendo intentar despues enviarle un bloque a un bizantino, primero buscar el proceso bizantino en la lista de procesos, sabemos cual es porque al principio los procesos te dicen su estado por ejemplo digamos que tenemos:

'Proceso con PID #PID<0.129.0>: Iniciando con estado %{vecinos: [], bizantino: true, blockchain: %Blockchain{chain: [%Block{data: "Genesis Block", timestamp: "2024-01-01 00:00:00Z", prev_hash: "0", hash: "2AF1E39"}]}, mensajes: %{prepare: [], commit: []}}
'

Vamos a hacer lo siguiente 

'
iex(*)> pid_buscado = :erlang.list_to_pid('<0.129.0>')
iex(*)> bizantino = Enum.find(procesos, fn pid -> pid == pid_buscado end)
iex(*)> send(bizantino, {:bloque, Block.new("Bloque 2", "<hash del ultimo bloque>")})
iex(*)> Enum.each(procesos, fn pid -> send(pid, {:estado, nil}) end)
'

Hacemos basicamente lo mismo pero como estamos enviando el bloque a un proceso bizantino entonces este proceso le dara igual nuestro bloque e intentara enviar un bloque basura, entonces la ultima linea enseñara que ningun proceso acepto el bloque en su BC.



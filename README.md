# Proyecto Final - Computación Distribuida

### **Integrantes del Equipo**
- **Ángeles Sánchez Aldo Javier** (320286144)
- **Sánchez Victoria Leslie Paola** (320170513)
- **Sosa Romo Juan Mario** (320051926)

---

### **Descripción del Proyecto**
Este proyecto consiste en desarrollar una **blockchain** para un sistema de criptomonedas como parte de la materia de Computación Distribuida. El sistema:
- Maneja múltiples procesos en **Elixir** que representan usuarios.
- Permite enviar mensajes, alcanzar consensos, y detectar y eliminar procesos maliciosos que intenten alterar la blockchain.

---

### **Documentación**
El proyecto cuenta con documentación, se encuentra en el path `Proyecto/src/doc/index.html` si lo ejecutas en un navegador te mostrara una vista con la documentación generada a partir de `ExDoc`.

---

### **Cómo Usar el Proyecto**

Dentro de la carpeta `src` encontrarás dos scripts:
- `interp.sh`
- `run.sh`

Ambos simplifican la compilación y ejecución del proyecto. Para usarlos, primero asigna permisos de ejecución con:

```bash
chmod +x interp.sh run.sh
```

### Opción 1: Ejecutar directamente el proyecto

```bash
./run.sh
```

Este comando:

1. **Ejecuta la función principal:**
   Llama a `Main.run/2` con los parámetros predeterminados (10 procesos en total, de los cuales 1 es bizantino).

2. **Crea una red de nodos:**
   Los procesos se organizan utilizando el modelo de **Wartz y Strogatz**, lo que les asigna vecinos de manera eficiente.

3. **Propone un bloque válido:**
   - Se genera un bloque válido y se envía al primer proceso para que lo proponga a la red.
   - Cada nodo verifica el bloque y, si es válido, lo agrega a su blockchain.

4. **Simula un intento de consenso con un bloque inválido:**
   - Se genera un bloque inválido deliberadamente y se intenta consensuar.
   - Ningún nodo acepta el bloque inválido, asegurando la integridad de la blockchain.

5. **Muestra el estado final de las blockchains:**
   Imprime el contenido de la blockchain de cada nodo, mostrando que solo los bloques válidos fueron aceptados.

---

### **Exploración en el Intérprete Interactivo**

Además de las funcionalidades preconfiguradas, el intérprete (`./interp.sh`) permite realizar pruebas más personalizadas, como:

- **Enviar bloques a nodos específicos:**
  Puedes probar cómo se comportan los nodos frente a bloques válidos o inválidos.

- **Observar el comportamiento de los nodos bizantinos:**
  Los nodos maliciosos intentarán sabotear el consenso generando bloques inválidos.

Ejemplo interactivo:
```elixir
iex(*)> procesos = Main.run(10, 1) # Crea 10 procesos (1 bizantino)
iex(*)> [normal | _] = procesos # Extrae un nodo normal
iex(*)> send(normal, {:bloque, Block.new("Bloque Válido", "<hash del último bloque>")}) # Enviar bloque válido
iex(*)> Enum.each(procesos, fn pid -> send(pid, {:estado, nil}) end) # Verifica el estado de cada nodo
```

### Resultado esperado

El bloque válido será aceptado por todos los nodos, y las blockchains de los nodos normales se actualizarán para incluir dicho bloque. La última línea del código interactivo, `Enum.each(procesos, fn pid -> send(pid, {:estado, nil}) end)`, imprimirá el estado de todos los nodos, donde cada uno debería mostrar que ha añadido el bloque válido a su blockchain.

---

### Comportamiento del Nodo Bizantino

Cuando se envía un bloque a un nodo bizantino, este ignorará el bloque válido e intentará enviar un bloque inválido o "basura" a la red. Aunque el nodo bizantino intenta manipular la blockchain, los nodos normales no aceptarán el bloque inválido. Así, el consenso se mantiene intacto.

Ejemplo interactivo:

```elixir
iex(*)> pid_buscado = :erlang.list_to_pid('<PID del proceso bizantino>')
iex(*)> bizantino = Enum.find(procesos, fn pid -> pid == pid_buscado end)
iex(*)> send(bizantino, {:bloque, Block.new("Bloque Inválido", "<hash del último bloque>")})
iex(*)> Enum.each(procesos, fn pid -> send(pid, {:estado, nil}) end)
```

### Resultado esperado

El proceso bizantino ignorará el bloque válido e intentará insertar un bloque inválido, pero este no será aceptado por la red. Al ejecutar `Enum.each`, se verificará que ningún nodo haya agregado el bloque inválido a su blockchain.

---

### Conclusion

Este proyecto te permite observar el comportamiento e interacciones entre procesos dentro de un red con ciertas caracteristicas, en general, vemos que el llegar a un consenso, especificamente sin el uso de sincronia y con algunos nodos maliciosos es bastante bastante complicado y aunque en este proyecto no implementamos nada muy fuerte para verificar los bloques, aún asi fue muy tedioso lidiar con problemas de sincronicidad y terminamos haciendo un sistema que utiliza casi exponencial en mensajes.


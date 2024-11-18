import React from "react";
import { useState } from "react";
import Admin from "./components/Admin.jsx";
import "./AppAdmin.css";

const App = () => {

    const [instance, SetInstance] = useState(1);

    function onGameOver () {
      SetInstance(2);
    }

   return (
      <Admin instance={instance} onGameOver={onGameOver}/>
   );
}

export default App
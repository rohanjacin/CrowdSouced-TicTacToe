import React from 'react'
import  { createRoot }  from 'react-dom/client';
import './app/index.css';
import App from './app/AppPlayer.js'

const container = document.getElementById('root');
const root = createRoot(container);
root.render(
    <App initialPlayerId={0}/>
);
import React from 'react'
import  { createRoot }  from 'react-dom/client';
import './app/index.css';
import App from './app/AppAdmin.js'

const container = document.getElementById('root');
const root = createRoot(container);
root.render(
    <App />
);
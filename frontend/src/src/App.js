import React from 'react';
import FinanceChart from './FinanceChart';
import QualifierChart from './QualifierChart';

function App() {
  return (
    <div>
      <h1>Dashboard</h1>
      <FinanceChart />
      <h2>qualifiers</h2>
      <QualifierChart />
    </div>
  );
}

export default App;
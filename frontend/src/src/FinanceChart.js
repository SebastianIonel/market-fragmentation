import React, { useEffect, useState } from 'react';
import {
  BarChart, Bar, CartesianGrid, XAxis, YAxis, Tooltip, Legend, ResponsiveContainer
} from 'recharts';

function FinanceChart() {
  const [data, setData] = useState([]);

  useEffect(() => {
    fetch("http://localhost:8000/interval-data")
      .then(res => res.json())
      .then(json => {
        const raw = json.data;

        // Reshape the data for Recharts
        const transformed = raw.sym.map((symbol, index) => ({
          sym: symbol,
          vwap: raw.vwap[index],
          maxbid: raw.maxbid[index],
          minask: raw.minask[index],
          lastmidprice: raw.lastmidprice[index],
        }));

        console.log("Transformed data:", transformed);
        setData(transformed);
      });
  }, []);

  return (
    <div style={{ width: '100%', height: 400 }}>
      <h2>Indicatori Financiari per Simbol</h2>
      <ResponsiveContainer>
        <BarChart data={data}>
          <CartesianGrid stroke="#ccc" />
          <XAxis dataKey="sym" />
          <YAxis />
          <Tooltip />
          <Legend />
          <Bar dataKey="vwap" fill="#8884d8" name="VWAP" />
          <Bar dataKey="maxbid" fill="#82ca9d" name="Max Bid" />
          <Bar dataKey="minask" fill="#ff7300" name="Min Ask" />
          <Bar dataKey="lastmidprice" fill="#413ea0" name="Last Mid Price" />
        </BarChart>
      </ResponsiveContainer>
    </div>
  );
}

export default FinanceChart;

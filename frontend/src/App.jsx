import React from "react";
import { useEffect, useState } from "react";

const API_BASE = import.meta.env.VITE_API_BASE || "http://localhost:8080";
const ML_BASE = import.meta.env.VITE_ML_BASE || "http://localhost:5000";

export default function App() {
  const [products, setProducts] = useState([]);
  const [recs, setRecs] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    Promise.all([
      fetch(`${API_BASE}/products`).then(r => r.json()).catch(() => []),
      fetch(`${ML_BASE}/recommendations/42`).then(r => r.json()).then(d => d.recommendations || []).catch(() => [])
    ]).then(([productsData, recsData]) => {
      setProducts(productsData);
      setRecs(recsData);
      setLoading(false);
    });
  }, []);

  return (
    <main>
      <h1>ShopMicro</h1>
      <p className="subtitle">Your personalized shopping experience</p>
      
      <h2>Products</h2>
      {loading ? (
        <p className="loading">Loading products...</p>
      ) : products.length === 0 ? (
        <p className="error">Unable to load products</p>
      ) : (
        <ul>
          {products.map(p => (
            <li key={p.id}>
              <span className="product-name">{p.name}</span>
              <span className="product-price">${p.price}</span>
            </li>
          ))}
        </ul>
      )}
      
      <h2>Recommended for You</h2>
      <span className="badge">User 42</span>
      {loading ? (
        <p className="loading">Loading recommendations...</p>
      ) : recs.length === 0 ? (
        <p className="error">Unable to load recommendations</p>
      ) : (
        <ul>
          {recs.map(r => (
            <li key={r}>
              <span className="product-name">{r}</span>
            </li>
          ))}
        </ul>
      )}
    </main>
  );
}

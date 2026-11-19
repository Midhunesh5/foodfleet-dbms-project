// Synthetic sample document based on the presentation's example.
db.restaurants.updateOne(
  { restaurant_id: 4 },
  {
    $set: {
      restaurant_id: 4,
      name: "Biryani House",
      cuisine: "Biryani",
      area: "Jayanagar",
      menu: [
        { item: "Chicken Biryani", price: 280, veg: false, times_ordered: 43 },
        { item: "Veg Biryani", price: 220, veg: true, times_ordered: 25 }
      ],
      reviews: [
        {
          customer_id: 17,
          rating: 5,
          comment: "Hot and fresh",
          tags: ["taste", "fast"]
        }
      ]
    }
  },
  { upsert: true }
);

db.restaurants.createIndex({ restaurant_id: 1 }, { unique: true });
db.restaurants.createIndex({ cuisine: 1 });
db.restaurants.createIndex({ "menu.price": 1 });
db.restaurants.createIndex({ "reviews.comment": "text" });

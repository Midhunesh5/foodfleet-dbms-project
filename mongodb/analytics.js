// CRUD examples.
db.restaurants.insertOne({
  restaurant_id: 99,
  name: "Demo Restaurant",
  cuisine: "Demo",
  area: "Demo",
  menu: [],
  reviews: []
});

db.restaurants.find({ cuisine: "Biryani" });

db.restaurants.updateOne(
  { restaurant_id: 4 },
  {
    $push: {
      reviews: {
        customer_id: 18,
        rating: 4,
        comment: "Good meal",
        tags: ["taste"]
      }
    }
  }
);

// Remove the temporary CRUD example document.
db.restaurants.deleteOne({ restaurant_id: 99 });

// Average rating and menu price range.
db.restaurants.aggregate([
  {
    $addFields: {
      min_price: { $min: "$menu.price" },
      max_price: { $max: "$menu.price" }
    }
  },
  { $unwind: "$reviews" },
  {
    $group: {
      _id: "$name",
      avg_rating: { $avg: "$reviews.rating" },
      min_price: { $first: "$min_price" },
      max_price: { $first: "$max_price" }
    }
  },
  { $sort: { avg_rating: -1 } },
  { $limit: 5 }
]);

// Most ordered menu item per restaurant.
db.restaurants.aggregate([
  { $unwind: "$menu" },
  { $sort: { "menu.times_ordered": -1 } },
  {
    $group: {
      _id: "$name",
      top_dish: { $first: "$menu.item" },
      orders: { $first: "$menu.times_ordered" }
    }
  },
  { $sort: { orders: -1 } },
  { $limit: 5 }
]);

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth_screens/login_screen.dart';
import '../../models/auth.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            primary: Colors.black,
            elevation: 3, // Add elevation for a more pronounced button
          ),
        ),
      ),
      home: const TaskScreen(),
    );
  }
}

class TaskScreen extends StatefulWidget {
  const TaskScreen({Key? key}) : super(key: key);

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyForUpdate = GlobalKey<FormState>();
  late TextEditingController _productController;
  late TextEditingController _priceController;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _productController = TextEditingController();
    _priceController = TextEditingController();
  }

  @override
  void dispose() {
    _productController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Listings', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.black,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    firebaseAuth.currentUser?.displayName ?? 'User',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    firebaseAuth.currentUser?.email ?? 'Email',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 16, top: 16),
                child: SizedBox(
                  width: 120, // Adjust width as needed
                  child: ElevatedButton(
                    onPressed: () async {
                      await UserAuth.clearUserAuth();
                      if (mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (cntxt) => const LoginScreen()),
                              (route) => false,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          width: double.infinity,
          child: StreamBuilder(
            stream: firestore.collection(firebaseAuth.currentUser!.uid).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator.adaptive());
              } else if (snapshot.hasError) {
                return Center(child: Text(snapshot.error.toString()));
              } else if (snapshot.hasData == true &&
                  snapshot.data!.docs.isEmpty == true) {
                return const Center(child: Text('No Product'));
              } else if (snapshot.data != null) {
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (cntxt, index) {
                    return Card(
                      elevation: 5,
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(
                          snapshot.data!.docs[index].get('product') ?? '',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'Price: \$${snapshot.data!.docs[index].get('price') ?? ''}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              onPressed: () async {
                                await updateProductShowModalBottomSheet(
                                  snapshot.data!.docs[index].get('product') ?? '',
                                  snapshot.data!.docs[index].get('price') ?? '',
                                  snapshot.data!.docs[index].id,
                                );
                              },
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.green,
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                await firestore
                                    .collection(firebaseAuth.currentUser!.uid)
                                    .doc(snapshot.data!.docs[index].id)
                                    .delete();
                              },
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else {
                return const Center(child: Text('------'));
              }
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addNewProductShowModalBottomSheet();
        },
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> addNewProductShowModalBottomSheet() async {
    showModalBottomSheet<void>(
      context: context,
      enableDrag: true,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(10),
        ),
      ),
      builder: (cntxt) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  controller: _productController,
                  decoration: const InputDecoration(
                    labelText: 'Product',
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Enter the product';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Enter the price';
                    }
                    if (!RegExp(r'^\d+\.?\d{0,2}$').hasMatch(value!)) {
                      return 'Enter a valid price';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate() == true) {
                      saveProduct();
                      Navigator.pop(context); // Close the bottom sheet after saving
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black,
                    onPrimary: Colors.white,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Add'),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    ).then((value) {
      _productController.clear();
      _priceController.clear();
    });
  }

  Future<void> saveProduct() async {
    String userId = firebaseAuth.currentUser!.uid;
    Map<String, dynamic> product = {
      'product': _productController.text.trim(),
      'price': _priceController.text.trim(),
    };
    firestore.collection(userId).doc().set(product).then((_) {
      log('Product Added.');
      _formKey.currentState!.reset();
    }).catchError((onError) {
      log(onError.toString());
    });
  }

  Future<void> updateProductShowModalBottomSheet(
      String product, String price, String documentId) async {
    _productController.text = product;
    _priceController.text = price;
    showModalBottomSheet<void>(
      context: context,
      enableDrag: true,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(10),
        ),
      ),
      builder: (cntxt) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Form(
            key: _formKeyForUpdate,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
                  'Update Product',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _productController,
                  decoration: const InputDecoration(
                    labelText: 'Product',
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Enter the product';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Enter the price';
                    }
                    if (!RegExp(r'^\d+\.?\d{0,2}$').hasMatch(value!)) {
                      return 'Enter a valid price';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    if (_formKeyForUpdate.currentState!.validate() == true) {
                      updateProduct(
                        _productController.text.trim(),
                        _priceController.text.trim(),
                        documentId,
                      );
                      Navigator.pop(context); // Close the bottom sheet after updating
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black,
                    onPrimary: Colors.white,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Update'),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    ).then((value) {
      _productController.clear();
      _priceController.clear();
    });
  }

  Future<void> updateProduct(
      String product, String price, String productId) async {
    String userId = firebaseAuth.currentUser!.uid;
    Map<String, dynamic> updatedProduct = {
      'product': product,
      'price': price,
    };

    firestore.collection(userId).doc(productId).update(updatedProduct).then((_) {
      log('Product Updated.');
      Navigator.pop(context);
    }).catchError((error) {
      log(error.toString());
    });
  }
}

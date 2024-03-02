import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget shimmerCategoryLoading() {
  return Container(
    margin: const EdgeInsets.only(bottom: 5),
    child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: ListView.builder(
              itemCount: 9,
              itemBuilder: (context, index) {
                return Container(
                  width: double.infinity,
                  height: 65,
                  margin: const EdgeInsets.only(top: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      width: 2,
                      color: Colors.black,
                    ),
                  ),
                );
              }),
        )),
  );
}

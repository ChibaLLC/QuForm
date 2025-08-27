#!/bin/bash

cd api
composer run dev &

cd ../client
pnpm dev

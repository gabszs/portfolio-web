---
author: Gabriel Carvalho
pubDatetime: 2024-10-19T23:30:41.816Z
title: Introduction to asyncio.gather()
slug: "introduction-to-asyncio-gather"
featured: true
tags:
  - asycio
  - async
  - python
  - coroutines
  - gather
description: "gather(): making python 100x (or even more) faster."
---

A Brief Introduction to the principles of parallelism in Python Using the asyncio.gather() Method,

We will explore concepts and demonstrate how to execute an array of coroutines concurrently, enhancing performance by allowing Python to manage multiple tasks simultaneously.

Also, an example of how I was able to achieve a code execution speed that was 100 times faster.

## Table of contents

## requirements

For this post, I will assume that you have a basic understanding of asyncio implementation in Python and its underlying concepts. However, for those who may not be as familiar, I will provide a comprehensive guide covering Python’s asyncio, coroutines, sub-routines, and parallelism. Additionally, I will update this article with a link to that guide as I write it.

## Context

### Thread run in Python

Every time that you run a script in python, python requires from system a thread to run the script individually, so, every time that you play the run button in vscode, the python will require a thread, and run the script inside.

There are also some frameworks that implement the use of multiple threads, such web-frameworks as FastApi and Django, so, every time that the server is on, the framework request multiples thread for its runnings (40 thread in FastApi for example), and every time that a request came to the server, the framework will re-direct to some of the available threads.

The code run-history, is much of the time sequential, and when you run a normal function, it blocks the entire thread until the function is completed.

### Coroutines in python

We can describe coroutines in python as non-blocking functions, so, a ffunction that can run simultaneously with others instead of running one at a time..

> In Python, asyncio is not about running multiple tasks in multiple threads; it is about running multiple tasks in a single thread, i.e., executing them with greater efficiency.

In python, we can express this by:
```py
# sub-routine
def sub_task():
    sleep(3)

# coroutine
async def async_task():
    asyncio.sleep(3)
```

So every time that we run sub_task() python will block the code waiting the function to be completed, but if async_task(), we can manage to run the function, but instead of block the python thread, work on another task while
this one is running, so we can multiple async_task at same time.

And to manage to run all of our async_task in parallel, there is a method in asyncio lib, called gather(), which basically enables us to run many of these coroutines. (async def functions)

### CPU-Bound vs IO-Bound

In the programming functions, there`re basically two types of function operations, the CPU-Bound, which is basically any function that requires intensive cpu power, and IO-Bound, functions that does not require intensive cpu work, but instead, needs to wait for another task to be completed. 

So, IO-Bound functions are basically functions that is not heavy, but waits long because of necessity of another service, for example:
```py
response = requests.get("another_service_endpoint") # IO-Bound operation
```

The question is, for the CPU-Bound operation, is not so necessary to heave a parallel run, since the task itself will require most of the power available. But with IO-Bound operations, the panorama is very different, since most of the runtime, the thread will be sub-used, which means that the cpu will have a lot of power available, the problem, is that if the function is a sub-routine, it will block the thread, so we need to made the function available for parallel run, with async, and with this will be able to to run a lot of IO-Bound operations at same time, saving a tom of time since we do not need to wait for every long io-bound operation to in queue 

## Gather()

With this context in mind, you can guess, that the X problem, is how to run multiple coroutines at same time, since if we use this type of code sequential struct:

```py
# coroutine
async def async_task():
    asyncio.sleep(3)

await async_task()
await async_task()
await async_task()
# this code will last 9 seconds
```

The code will last as same as:

```py
# subroutine
def sub_task():
    sleep(3)

sub_task()
sub_task()
sub_task()
# this code will last 9 seconds
```
because of sequential run, even though the the async_task being a sub-routine, since we run the task in a sequential way, i.e, one at time, its provides the same behavior of a sub-routine.

To resolve this, the asyncio lib implements a method called gather(), a method that inputs a array of coroutines, and run all of then at same time, bassically, there are just a few steps to implement this parallel structure.

- Get the coroutines
- Package all of the intendend sub-routines inside a list
- Input the unpackaged list into the gather method
- Outputs the result (if the function has any return statment)

> Notice that to store a coroutines withou running it, you just need to call the funcation with "()" without await
>
>```python
># intead of using await async_method(), just use async_method()
>async def async_method():
>    asyncio.sleep(3)
>
>coroutines = []
>for _ in range(3):
>    coroutine = async_method()  
>    coroutines.append(coroutine)
>```

If that in mind, lets go to examples:

> A few months ago, I built a service to generate random passwords, so that I implemented the parallel logics inside it, you can check the password use case in this [repo file](https://github.com/gabszs/FastApi--Password-Generator/blob/main/app/use_cases/password.py). For the example, lets assume that we already have the class.

```py
""" 
So, we have a class that the methods returns to us a password, 
but instead of call every run sequentially,
- we build the coroutines without await 
- stores into a list 
- and lather run inside gather
"""
pg = PasswordGenerator() # -> Instantiate the password use case class
corroutines = list() # -> create a list to store the coros

for number in range(quantity): # creates a loop by quantity to build our coros

    # notice, that I do not user the await
    coro = pg.async_pin(pin_lenght=password_lenght) 
    coroutines.append(coro) 

# unpackage the coros inside gather, and then run all the coros in parallel
gather_result = await gather(*coroutines)

print(gather_result)

```

## Conclusion

With this context and examples, I manage to not even hundreds, but thousands of operations simultaneously, saving me time while using the thread efficiently.

You can try to implement the sub-routines in your code, thinks about it, you just need to transform your basic functions into coroutines, notice with that, usually, you need to re-built some of your code to async libs. for example lets use the open() files implementation.

```py
import asyncio
import aiofiles
import time

# Synchronous file read code
def read_file_sync(file_path):
    with open(file_path, 'r') as f:
        return f.read()

# Re-implementation of the file code using an async library
async def read_file_async(file_path):
    async with aiofiles.open(file_path, 'r') as f:
        return await f.read()
```

We used this type of logic in one of our job tasks and managed to decrease the file writing speed by a factor of 50.

Try building asynchronous code yourself, and you'll notice that you can significantly improve your code's efficiency by hundreds, if not thousands, of times.

If you like the post, had any feedback or question, you can send me a message on [whatsapp](https://wa.me/5511947047830) or [email](mailto:gabrielcarvalho.workk@gmail.dev).

By [Gabriel Carvalho](https://www.linkedin.com/in/gabzsz/) <br/>

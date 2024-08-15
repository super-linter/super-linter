// Copyright (c) Microsoft.  All Rights Reserved.  Licensed under the MIT license.  See License.txt in the project root for license information.

using System.Threading;

var rootCommand = RootFormatCommand.GetCommand();
return await rootCommand.Parse(args).InvokeAsync(CancellationToken.None);

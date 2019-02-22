using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace PasswordGenerator
{
    class Program
    {
        [STAThread]
        static void Main(string[] args)
        {
            int grade,length;
            grade = 0;
            Random r = new Random();
            bool flag = true;
            string randomPass = "";
            Console.ForegroundColor = ConsoleColor.Yellow;
            Console.Title = "Password Generator";
            while (flag)
            {
                Console.ForegroundColor = ConsoleColor.Yellow;
                Console.WriteLine("\nPleae Chose The Grade of complexility :\n");
                Console.WriteLine("1.Only lowerCase Alphabet");
                Console.WriteLine("2.UpperCase and lowerCase Alphabet");
                Console.WriteLine("3.UpperCase and lowerCase Alphabet and Numbers");
                Console.WriteLine("4.UpperCase and lowerCase Alphabet and Numbers and Signs ");

                grade = Convert.ToInt32(Console.ReadLine());
                if (grade > 0 && grade < 5) flag = false;
                else
                {
                    Console.Clear();
                    Console.ForegroundColor = ConsoleColor.Red;
                    Console.WriteLine("\nThe choice should be between 1-4");
                    flag = true;
                }
            }
            Console.WriteLine("\nPleae Chose The Length of Password :\n");

            length = Convert.ToInt32(Console.ReadLine());
            Console.WriteLine("grade is : " + grade + "  Length is :" + length);
            for (int i = 0; i < length; i++)
            {
                var chartype = r.Next(1,grade+1);
                switch(chartype)
                {
                    case 1:
                        randomPass += (char)r.Next(97, 123);
                        break;
                    case 2:
                        randomPass += (char)r.Next(65, 91);
                        break;

                    case 3:
                        randomPass += (char)r.Next(48, 58);
                        break;
                    case 4:
                        {
                            chartype = r.Next(1, 5);
                            switch(chartype)
                            {
                                case 1:
                                    randomPass += (char)r.Next(33, 48);
                                    break;
                                case 2:
                                    randomPass += (char)r.Next(58, 65);
                                    break;
                                case 3:
                                    randomPass += (char)r.Next(91, 97);
                                    break;
                                case 4:
                                    randomPass += (char)r.Next(123, 127);
                                    break;
                            }
                        }
                        break;
                }


            }
            Console.WriteLine("Your Password is:  " + randomPass);
            Clipboard.SetText(randomPass);
            Console.ReadKey();
            




        }
    }
}
